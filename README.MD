# Docker Utility

A simple shell script to manage Docker containers on a server using the Docker CLI. Containers are managed with a special label (`managed-by=docker-utility`) and can be created, listed, restarted, updated, and removed using this utility.

## Features
- **Create** containers with `--restart=always` and custom options
- **List** all managed containers
- **Restart** a managed container by name
- **Update** a container (pulls image, recreates with original options)
- **Remove** a container from inventory and delete it
- **Show original args** for a container
- **Debug mode**: print traced Docker commands in color
- **Colored output** for success (green) and errors (red)
- **Proper error handling**: script exits with error code on failure

## Usage

```sh
./docker-utility.sh [--debug] {create|list|restart|update|remove|args} [options]
```

### Options
- `--debug`  
  Print traced Docker commands in cyan before execution.

### Commands
- `create <name> <image> [docker run args...]`  
  Create a new managed container with the given name, image, and any additional `docker run` options.
- `list`  
  List all containers managed by this utility.
- `args <name>`  
  Show the original docker run arguments used to create the container.
- `restart <name>`  
  Restart a managed container by name.
- `update <name>`  
  Pull the latest image and recreate the container with the original options.
- `remove <name>`  
  Stop and remove a managed container by name.

## Example

```sh
# Create a container
./docker-utility.sh create myapp nginx:alpine -p 8080:80 -e ENV=prod

# List managed containers
./docker-utility.sh list

# Show original args
./docker-utility.sh args myapp

# Restart a container
./docker-utility.sh restart myapp

# Update a container
./docker-utility.sh update myapp

# Remove a container
./docker-utility.sh remove myapp

# Debug mode (show traced commands)
./docker-utility.sh --debug update myapp
```

## Notes
- Only containers created with this utility (with the special label) are managed.
- The script stores the original `docker run` options in a label for reliable updates.
- Requires Docker CLI and `base64` utility.
- Success messages are shown in green, errors in red, and traced commands in cyan (when using `--debug`).
