#!/usr/bin/env ruby

# Finds all of the Terraform modules and deployments which have changed on a branch

base_commit_hash = ARGV[0]
head_commit_hash = ARGV[1]

all_changed_files = `git diff "#{base_commit_hash}...#{head_commit_hash}" --name-only`

if $? != 0 then
    exit 1
end

changed_tf_files = all_changed_files.split("\n").select {|f| /infra\/.*\.tf(?:\.json)?/.match(f) }
    
affected_deployments =
    changed_tf_files
        .select {|f| f.start_with?("infra/deployments/")}
        .map {|f| f.split("/").take(4).join("/")}
        .uniq
        
affected_modules =
    changed_tf_files
        .select {|f| f.start_with?("infra/modules/")}
        .map {|f| f.split("/").take(3).join("/")}
        .uniq
        
all = affected_deployments + affected_modules

puts all
