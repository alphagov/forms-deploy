# Well-Known modules

These are simple data modules. These should be created / used in cases where passing `remote-state` data around is cumbersome and adds clutter.

They should be used both when creating new resources with specific names, and when consuming those resources.

## Why "well-known"

The name `well-known` is inspired by the concept of "Well-Known URIs" defined in [RFC 8615](https://datatracker.ietf.org/doc/html/rfc8615).

In the IETF standard, a "well-known" location is a predictable, standardised place where clients can reliably discover configuration or metadata without needing environment-specific knowledge.

We apply the same idea here: this directory acts as a single, canonical source of truth for identifiers, names, and ARNs that are identical across all environments.

Instead of duplicating the same constant values in every `tfvars` file or scattering naming logic across modules, the well-known module provides a stable, intentional lookup point.

Treat it as the Terraform equivalent of a well-known discovery path — a structured, predictable location for values that must be globally consistent (e.g., AWS accounts).
