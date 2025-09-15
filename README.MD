# Docker Utility

A simple shell script to manage Docker containers on a server using the Docker CLI. Containers are managed with a special label (`managed-by=docker-utility`) and can be created, listed, restarted, updated, removed, exported, and imported using this utility.

## Features
- **Create** containers with `--restart=always` and custom options
- **List** all managed containers
- **Restart** a managed container by name
- **Update** a container (pulls image, recreates with original args)
- **Remove** a container from inventory and delete it
- **Show original args** for a container
- **Export** all managed containers to JSON (with args as plain text)
- **Import** containers from JSON (with args as plain text)
- **Debug mode**: print traced Docker commands in color
- **Colored output** for success (green) and errors (red)
- **Proper error handling**: script exits with error code on failure
- **Show utility version**
- 
## Usage

```sh
./docker-utility.sh [--debug] {create|list|restart|update|remove|args|export|import} [options]
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
  Pull the latest image and recreate the container with the original args.
- `remove <name>`  
  Stop and remove a managed container by name.
- `export`  
  Export all managed containers to JSON (to stdout). The JSON will have fields: `name`, `image`, and `args` (plain text, not encoded).
- `import`  
  Import containers from JSON (from stdin). The JSON must have fields: `name`, `image`, and `args` (plain text, not encoded).

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

# Export all managed containers to a file
./docker-utility.sh export > containers.json

# Import containers from a file
./docker-utility.sh import < containers.json

# Debug mode (show traced commands)
./docker-utility.sh --debug update myapp
```

## Notes
- Only containers created with this utility (with the special label) are managed.
- The script stores the original `docker run` args in a label for reliable updates.
- Export/import uses the `args` field in JSON as plain text (not encoded).
- Requires Docker CLI, `jq`, and `base64` utility.
- Success messages are shown in green, errors in red, and traced commands in cyan (when using `--debug`).
