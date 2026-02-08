# Troubleshooting Guide

## Common Errors and Solutions

### Error: "No module named src.led_display_controller"

**Problem**: The Python module path was incorrect in the original Dockerfile.

**Solution**: This has been fixed in the updated Dockerfiles. The correct command is:
```bash
python src/led_display_controller.py
```
Not:
```bash
python -m src.led_display_controller  # WRONG
```

**If you already built the image**, rebuild it:
```bash
# Pull the latest Dockerfile
# Then rebuild
docker build -t yourusername/peerless-assassin-lcd:latest .

# Or use the automated script
./docker-deploy.sh
```

### Verify the Fix

Test if the controller starts correctly:
```bash
docker run --rm --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd:latest
```

You should see the controller start (or complain about not finding the USB device, which is expected if it's not connected).

### For GUI Mode

The GUI should be run with:
```bash
python src/led_display_ui.py
```

Not:
```bash
python -m src.led_display_ui  # WRONG
```

---

## Other Common Issues

### USB Device Not Found

**Error**: `Could not find USB device` or similar

**Check**:
1. Is the device plugged in?
   ```bash
   lsusb | grep -i thermal
   ```

2. Does the container have USB access?
   ```bash
   docker run --rm --privileged --device=/dev/bus/usb \
     yourusername/peerless-assassin-lcd lsusb
   ```

3. Are udev rules set up on the host?
   ```bash
   # Add udev rule (on host, not in container)
   echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="d004", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/99-thermalright.rules
   
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

### Container Exits Immediately

**Check logs**:
```bash
docker logs peerless-lcd
```

**Common causes**:
- USB device not found (see above)
- Configuration file errors
- Missing dependencies

**Debug with interactive shell**:
```bash
docker run -it --rm --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd bash
  
# Then manually try to run
python src/led_display_controller.py
```

### Permission Denied on /dev/bus/usb

**Solution 1**: Run with `--privileged`
```bash
docker run -d --privileged ...
```

**Solution 2**: Add user to plugdev group on host
```bash
sudo usermod -a -G plugdev $USER
# Log out and back in
```

**Solution 3**: Fix USB device permissions
```bash
sudo chmod 666 /dev/bus/usb/*/*
# Note: This is temporary and not recommended for production
```

### Config File Not Found

**Error**: `Could not find config.json` or similar

**Solution**: Mount the config file
```bash
docker run -d \
  ... \
  -v $(pwd)/config.json:/app/config.json:ro \
  ...
```

Make sure `config.json` exists in your current directory.

### GUI: Cannot Open Display

**Linux**:
```bash
# Allow Docker to access X11
xhost +local:docker

# Run with proper DISPLAY variable
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  ...
```

**macOS**: Install and configure XQuartz (see GUI_ACCESS.md)

**Windows/WSL2**: Install an X server like VcXsrv (see GUI_ACCESS.md)

### Import Errors

**Error**: `ModuleNotFoundError: No module named 'xyz'`

**Solution**: Rebuild the image to ensure all dependencies are installed
```bash
docker build --no-cache -t yourusername/peerless-assassin-lcd:latest .
```

### CPU/GPU Temperature Not Reading

**Check**:
1. Is `/sys` mounted?
   ```bash
   docker run --rm -v /sys:/sys:ro yourusername/peerless-assassin-lcd ls -la /sys/class/hwmon/
   ```

2. Are temperature sensors available on host?
   ```bash
   sensors  # on host
   ls /sys/class/hwmon/
   ```

3. Try mounting as read-write (less secure):
   ```bash
   -v /sys:/sys:rw
   ```

---

## Debugging Tips

### Check What's in the Container

```bash
# List files in the container
docker run --rm yourusername/peerless-assassin-lcd ls -la /app/

# Check Python can import
docker run --rm yourusername/peerless-assassin-lcd python -c "import sys; print(sys.path)"

# Verify dependencies
docker run --rm yourusername/peerless-assassin-lcd pip list
```

### Run Container Interactively

```bash
docker run -it --rm \
  --privileged \
  --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd \
  bash

# Inside container, you can:
# - Check files: ls -la
# - Try running: python src/led_display_controller.py
# - Check USB: lsusb
# - Check sensors: cat /sys/class/hwmon/hwmon*/temp*_input
```

### View Real-time Logs

```bash
# Follow logs
docker logs -f peerless-lcd

# Last 100 lines
docker logs --tail 100 peerless-lcd

# With timestamps
docker logs -f --timestamps peerless-lcd
```

### Check Container Stats

```bash
docker stats peerless-lcd
```

---

## Quick Commands Reference

```bash
# Rebuild image
docker build -t yourusername/peerless-assassin-lcd:latest .

# Stop and remove container
docker stop peerless-lcd && docker rm peerless-lcd

# Run with debug output
docker run -it --rm --privileged --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  yourusername/peerless-assassin-lcd

# Check if container is running
docker ps | grep peerless

# Inspect container
docker inspect peerless-lcd

# Execute command in running container
docker exec -it peerless-lcd bash
docker exec peerless-lcd cat /app/config.json
docker exec peerless-lcd lsusb

# Clean up everything
docker stop peerless-lcd
docker rm peerless-lcd
docker rmi yourusername/peerless-assassin-lcd
```

---

## Still Having Issues?

1. **Check the original repository** for any updates:
   https://github.com/raffa0001/Peerless_assassin_and_CLI_UI

2. **Try running natively** (outside Docker) to verify it works:
   ```bash
   git clone https://github.com/raffa0001/Peerless_assassin_and_CLI_UI.git
   cd Peerless_assassin_and_CLI_UI
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   python src/led_display_controller.py
   ```

3. **Check Docker logs** for specific error messages

4. **Verify all prerequisites** are met on the host system
