# Docker Utility

A simple shell script to manage Docker containers on a server using the Docker CLI. Containers are managed with a special label (`managed-by=docker-utility`) and can be created, listed, started, stopped, restarted, updated, reloaded, removed, exported, and imported using this utility.

## Download

You can download the script directly from GitHub:

- **Latest stable release:**
  ```sh
  curl -fsSL -o docker-utility.sh \
    https://github.com/feedbee/docker-utility/releases/download/v1.3.0/docker-utility.sh \
    && chmod +x docker-utility.sh
  ```
- **Latest from main branch:**
  ```sh
  curl -fsSL -o docker-utility.sh \
    https://raw.githubusercontent.com/feedbee/docker-utility/main/docker-utility.sh \
    && chmod +x docker-utility.sh
  ```

## Features
- **Create** containers with `--restart=always` and custom options
- **List** all managed containers
- **Show original args** for a container
- **Start/Stop** a managed container by name
- **Restart** a managed container by name
- **Reload** a container (recreates with original args, useful for catching up with changes in .evn files)
- **Update** a container (pulls image, recreates with original args)
- **Remove** a container from inventory and delete it
- **Export** all managed containers to stdout in JSON or CSV format
- **Import** containers from stdin in JSON or CSV format
- **Show utility version**
- **Debug mode**: print traced Docker commands in color
- **Colored output** for success (green) and errors (red)
- **Proper error handling**: script exits with error code on failure

## Usage

```sh
./docker-utility.sh [--debug] {create|list|args|start|stop|restart|update|reload|remove|export|import|version} [options]
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
- `start <name>`  
  Start a managed container by name.
- `stop <name>`  
  Stop a managed container by name.
- `restart <name>`  
  Restart a managed container by name.
- `reload <name>`  
  Recreate the container with the original args, without pulling the image (useful for config changes).
- `update <name>`  
  Pull the latest image and recreate the container with the original args.
- `remove <name>`  
  Stop and remove a managed container by name.
- `export [--csv]`  
  Export all managed containers to stdout in JSON (default) or CSV (if --csv is provided) format.
- `import [--csv]`  
  Import containers from stdout in JSON (default) or CSV (if --csv is provided) format.
- `version`  
  Show the utility version.

## Example

```sh
# Create a container
./docker-utility.sh create myapp nginx:alpine -p 8080:80 -e ENV=prod

# List managed containers
./docker-utility.sh list

# Show original args
./docker-utility.sh args myapp

# Start a container
./docker-utility.sh start myapp

# Stop a container
./docker-utility.sh stop myapp

# Restart a container
./docker-utility.sh restart myapp

# Reload a container
./docker-utility.sh reload myapp

# Update a container
./docker-utility.sh update myapp

# Remove a container
./docker-utility.sh remove myapp

# Export all managed containers to a file (JSON)
./docker-utility.sh export > containers.json

# Export all managed containers to a file (CSV)
./docker-utility.sh export --csv > containers.csv

# Import containers from a file (JSON)
./docker-utility.sh import < containers.json

# Import containers from a file (CSV)
./docker-utility.sh import --csv < containers.csv

# Show utility version
./docker-utility.sh version

# Debug mode (show traced commands)
./docker-utility.sh --debug update myapp
```

## Notes
- Only containers created with this utility (with the special label) are managed.
- The script stores the original `docker run` args in a label for reliable updates.
- Export/import uses the `args` field in JSON as plain text (not encoded).
- Requires Docker CLI, `jq`, and `base64` utility.
- Success messages are shown in green, errors in red, and traced commands in cyan (when using `--debug`).
