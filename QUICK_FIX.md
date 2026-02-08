# QUICK FIX: Finding the Correct Entry Point

## The Problem

You're getting: `python: can't open file '/app/src/led_display_controller.py': [Errno 2] No such file or directory`

This means the file doesn't exist at that path. We need to find out what files actually exist in the `src/` directory.

## Solution 1: Find Out What Files Exist (RECOMMENDED)

Run the updated Dockerfile which will show you what files are available:

```bash
# Rebuild with the new Dockerfile
docker build -t yourusername/peerless-assassin-lcd:latest .

# Run it - it will show you the files
docker run --rm yourusername/peerless-assassin-lcd:latest
```

It will output something like:
```
Available files in src/:
-rw-r--r-- 1 peerless peerless  1234 file1.py
-rw-r--r-- 1 peerless peerless  5678 file2.py
...
```

Then, once you know the correct filename, run:
```bash
docker run -d --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  python src/CORRECT_FILENAME.py
```

## Solution 2: Check the Repository Directly

```bash
# Clone the repository
git clone https://github.com/raffa0001/Peerless_assassin_and_CLI_UI.git
cd Peerless_assassin_and_CLI_UI

# List files in src directory
ls -la src/

# Look for files like:
# - __main__.py (if it's a package)
# - main.py (common entry point)
# - led_display_controller.py
# - led_controller.py
# - Any other .py file that looks like an entry point
```

## Solution 3: Check the install.sh Script

The `install.sh` script creates a systemd service that runs the program. Look at what command it uses:

```bash
# Download and check install.sh
curl -s https://raw.githubusercontent.com/raffa0001/Peerless_assassin_and_CLI_UI/main/install.sh | grep -A5 "ExecStart"
```

This will show you the exact command used to run the program.

## Solution 4: Use the Package as a Module

If the project has a `src/__main__.py` file, you can run it as a module:

```bash
docker run -d --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  python -m src
```

## Most Likely Correct Commands

Based on common Python project structures, try these in order:

### Option A: Run as a module
```bash
docker run -d --name peerless-lcd --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  python -m src
```

### Option B: Run main.py
```bash
docker run -d --name peerless-lcd --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  python src/main.py
```

### Option C: Run led_controller.py (without "display_")
```bash
docker run -d --name peerless-lcd --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  python src/led_controller.py
```

### Option D: Use LED control script
```bash
docker run -d --name peerless-lcd --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest \
  ./led_control.sh
```

## Once You Find the Correct File

Update your Dockerfile CMD line to use the correct path:

```dockerfile
CMD ["python", "src/CORRECT_FILENAME.py"]
```

Then rebuild:
```bash
docker build -t yourusername/peerless-assassin-lcd:latest .
```

## For the GUI

The GUI file is likely one of:
- `src/led_display_ui.py` ✓ (most likely based on the README)
- `src/ui.py`
- `src/gui.py`

Run it with:
```bash
xhost +local:docker
docker run -it --rm --privileged --device=/dev/bus/usb \
  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \
  yourusername/peerless-assassin-lcd:latest \
  python src/led_display_ui.py
xhost -local:docker
```

## Need More Help?

If you're still stuck, please run these commands and share the output:

```bash
# Build and check the image
docker build -t test-peerless .
docker run --rm test-peerless ls -laR

# Or check the actual repository
git clone https://github.com/raffa0001/Peerless_assassin_and_CLI_UI.git temp-check
find temp-check/src -name "*.py" -type f
rm -rf temp-check
```

This will show all Python files in the project, and we can identify the correct entry point.
