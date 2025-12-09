#!/usr/bin/env bash
set -euo pipefail

echo "=== Drift Detection for ${DEPLOYMENT_NAME} ==="
echo "Timestamp: $(date -Iseconds)"
echo ""

# Clone repository (full history needed to compare against stored SHAs)
echo "Cloning repository: ${GIT_REPOSITORY_URL}"
git clone --single-branch --branch "${GIT_BRANCH}" "${GIT_REPOSITORY_URL}" /tmp/repo
cd /tmp/repo || exit

CURRENT_SHA=$(git rev-parse HEAD)
echo "Current HEAD: ${CURRENT_SHA}"
echo ""

# Function to build module dependency tree for a given terraform directory
# Returns absolute paths to all local module dependencies (recursive)
function build_module_dependency_tree() {
    local target_dir="$1"

    # Use associative array to track seen modules (deduplication)
    declare -A seen_modules
    declare -a module_queue
    declare -a dependencies

    # Extract local module sources from a directory
    function extract_module_sources() {
        local dir="$1"
        local temp_json

        # Find all .tf files that contain module blocks
        local tf_files
        tf_files=$(grep -l 'module[[:space:]]*"' "$dir"/*.tf 2>/dev/null || true)

        [ -z "$tf_files" ] && return

        # Process each file
        while IFS= read -r tf_file; do
            [ -z "$tf_file" ] && continue

            # Convert HCL to JSON
            temp_json=$(mktemp)
            if ! hcl2json "$tf_file" >"$temp_json"; then
                rm -f "$temp_json"
                continue
            fi

            # Extract module sources using jq
            # Only process local modules (relative paths starting with . or /)
            local sources
            sources=$(jq -r '
                .module // {} |
                to_entries[] |
                .value[] |
                .source // empty |
                select(startswith("./") or startswith("../") or startswith("/"))
            ' "$temp_json" 2>/dev/null || true)

            rm -f "$temp_json"

            if [ -n "$sources" ]; then
                while IFS= read -r source; do
                    [ -z "$source" ] && continue

                    # Resolve relative path to absolute path
                    local abs_source
                    abs_source="$(cd "$dir" && cd "$source" && pwd 2>/dev/null || echo "")"

                    [ -z "$abs_source" ] && continue
                    [ ! -d "$abs_source" ] && continue

                    echo "$abs_source"
                done <<<"$sources"
            fi
        done <<<"$tf_files"
    }

    # Add a module to the queue if not already seen
    function enqueue_module() {
        local module_path="$1"

        if [ -z "${seen_modules[$module_path]:-}" ]; then
            seen_modules[$module_path]=1
            module_queue+=("$module_path")
        fi
    }

    # Find all modules directly used by target directory
    local initial_modules
    initial_modules=$(extract_module_sources "$target_dir")

    [ -z "$initial_modules" ] && return

    # Initialize queue with direct dependencies
    while IFS= read -r module_path; do
        [ -z "$module_path" ] && continue
        enqueue_module "$module_path"
    done <<<"$initial_modules"

    # Process queue with breadth-first search
    while [ ${#module_queue[@]} -gt 0 ]; do
        # Dequeue first element
        local current_module="${module_queue[0]}"
        module_queue=("${module_queue[@]:1}")

        # Add to dependencies list
        dependencies+=("$current_module")

        # Find modules used by this module
        local child_modules
        child_modules=$(extract_module_sources "$current_module")

        if [ -n "$child_modules" ]; then
            while IFS= read -r child_module; do
                [ -z "$child_module" ] && continue
                enqueue_module "$child_module"
            done <<<"$child_modules"
        fi
    done

    # Output results
    for dep in "${dependencies[@]}"; do
        echo "$dep"
    done
}

# Get list of all roots for this deployment
echo "=== Querying SSM parameters for ${DEPLOYMENT_NAME} roots ==="
SSM_PREFIX="/terraform/last_applied/${DEPLOYMENT_NAME}/"

# Track results
TOTAL_ROOTS=0
UP_TO_DATE_COUNT=0
DRIFT_DETECTED_COUNT=0
MISSING_SHA_COUNT=0
DRIFTED_ROOTS=()

# Check each root
while IFS= read -r PARAM_NAME; do
    [ -z "$PARAM_NAME" ] && continue
    TOTAL_ROOTS=$((TOTAL_ROOTS + 1))

    # Extract root path from parameter name
    # /terraform/last_applied/deploy/account -> deploy/account
    ROOT_PATH="${PARAM_NAME#/terraform/last_applied/}"

    echo "--- Checking: ${ROOT_PATH} ---"

    # Get stored SHA from SSM (extract sha field from JSON blob)
    STORED_SHA=$(aws ssm get-parameter --name "${PARAM_NAME}" --query 'Parameter.Value' --output text 2>/dev/null | jq -r '.sha' 2>/dev/null || echo "")

    if [ -z "$STORED_SHA" ]; then
        echo "  ❌ MISSING: No SHA stored in SSM"
        MISSING_SHA_COUNT=$((MISSING_SHA_COUNT + 1))
        DRIFTED_ROOTS+=("${ROOT_PATH} (no SHA)")
        echo ""
        continue
    fi

    echo "  Stored SHA: ${STORED_SHA}"

    # Check if SHA exists in repo
    if ! git cat-file -e "${STORED_SHA}" 2>/dev/null; then
        echo "  ⚠️  WARNING: Stored SHA not found in repository"
        DRIFT_DETECTED_COUNT=$((DRIFT_DETECTED_COUNT + 1))
        DRIFTED_ROOTS+=("${ROOT_PATH} (SHA not in repo)")
        echo ""
        continue
    fi

    # Check if directory has changed since stored SHA
    ROOT_DIR="infra/deployments/${ROOT_PATH}"

    if [ ! -d "${ROOT_DIR}" ]; then
        echo "  ⚠️  WARNING: Directory does not exist: ${ROOT_DIR}"
        DRIFT_DETECTED_COUNT=$((DRIFT_DETECTED_COUNT + 1))
        DRIFTED_ROOTS+=("${ROOT_PATH} (dir missing)")
        echo ""
        continue
    fi

    # Check for changes between stored SHA and current HEAD
    # Includes the root directory AND its module dependencies

    # Build list of module dependencies for this root
    echo "  Building module dependency tree..."
    DEPENDENT_MODULES=$(build_module_dependency_tree "$ROOT_DIR" 2>/dev/null || echo "")

    # Build git pathspec array: root dir + dependent modules
    PATHSPEC_ARRAY=("${ROOT_DIR}")
    if [ -n "$DEPENDENT_MODULES" ]; then
        while IFS= read -r module_path; do
            [ -z "$module_path" ] && continue
            PATHSPEC_ARRAY+=("${module_path}")
        done <<<"$DEPENDENT_MODULES"
    fi

    if git diff --exit-code "${STORED_SHA}..HEAD" -- "${PATHSPEC_ARRAY[@]}" >/dev/null 2>&1; then
        echo "  ✅ UP TO DATE: No changes detected"
        UP_TO_DATE_COUNT=$((UP_TO_DATE_COUNT + 1))
    else
        echo "  ⚠️  DRIFT DETECTED: Changes found since last apply"

        # Show changed files in root
        ROOT_CHANGES=$(git diff --name-only "${STORED_SHA}..HEAD" -- "${ROOT_DIR}")
        if [ -n "$ROOT_CHANGES" ]; then
            echo "  Changed files in root:"
            while IFS= read -r file; do
                echo "    - ${file}"
            done <<<"$ROOT_CHANGES"
        fi

        # Show changed files in dependent modules
        if [ ${#PATHSPEC_ARRAY[@]} -gt 1 ]; then
            # Get changes from module paths only (skip first element which is ROOT_DIR)
            MODULE_PATHS=("${PATHSPEC_ARRAY[@]:1}")
            MODULE_CHANGES=$(git diff --name-only "${STORED_SHA}..HEAD" -- "${MODULE_PATHS[@]}" 2>/dev/null || true)
            if [ -n "$MODULE_CHANGES" ]; then
                echo "  Changed files in dependent modules:"
                while IFS= read -r file; do
                    echo "    - ${file}"
                done <<<"$MODULE_CHANGES"
            fi
        fi

        DRIFT_DETECTED_COUNT=$((DRIFT_DETECTED_COUNT + 1))
        DRIFTED_ROOTS+=("${ROOT_PATH}")
    fi

    echo ""
done < <(aws ssm describe-parameters \
    --parameter-filters "Key=Name,Option=BeginsWith,Values=${SSM_PREFIX}" \
    --query 'Parameters[].Name' \
    --output text | tr '\t' '\n')

# Check if any parameters were found
if [ ${TOTAL_ROOTS} -eq 0 ]; then
    echo "ERROR: No SSM parameters found for deployment: ${DEPLOYMENT_NAME}"
    exit 1
fi

echo ""

# Print summary
echo "==================================================================="
echo "=== DRIFT DETECTION SUMMARY ==="
echo "==================================================================="
echo "Deployment:        ${DEPLOYMENT_NAME}"
echo "Total roots:       ${TOTAL_ROOTS}"
echo "Up to date:        ${UP_TO_DATE_COUNT}"
echo "Drift detected:    ${DRIFT_DETECTED_COUNT}"
echo "Missing SHA:       ${MISSING_SHA_COUNT}"
echo ""

if [ ${DRIFT_DETECTED_COUNT} -gt 0 ] || [ ${MISSING_SHA_COUNT} -gt 0 ]; then
    echo "⚠️  ATTENTION REQUIRED: ${#DRIFTED_ROOTS[@]} root(s) need review:"
    for ROOT in "${DRIFTED_ROOTS[@]}"; do
        echo "  - ${ROOT}"
    done
    echo ""
    echo "These roots may need to be reapplied to match the current codebase."
    exit 2
else
    echo "✅ All roots are up to date!"
    exit 0
fi
