# Best Practices for Containerization

## Why Containerize?

* Use declarative formats for setup automation, to minimize time and cost for new developers joining the project;
* Have a clean contract with the underlying operating system, offering maximum portability between execution environments;
* Are suitable for deployment on modern cloud platforms, obviating the need for servers and systems administration;
* Minimize divergence between development and production, enabling continuous deployment for maximum agility;
* And can scale up without significant changes to tooling, architecture, or development practices.

* Shared kernel, but nothing else
* Uses cgroups, no virtualisation
* Ephemeral -- never any dirty state

## Why Kubernetes?

* What is it?
* Whats the cost?
  * Learning cost
  * A bit of overhead setting up a project (chart, etc.)
* Why?
  * Easy scaling
  * Efficient resourcing
  * Less dependence on system administrators
  * Standardised dev-to-operations for many different applications (just teach them the application config, everything "helm" stays the same)

## Tools

* Skaffold
* Helm

## Repository Structure

* Source + Dockerfile + skaffold.yaml
* Chart
* Config

## Configuration

* Hierarchical configuration
* 

## CI/CD

* Coming soon
