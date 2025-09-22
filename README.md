# ghostscript-wasm

`ghostscript` compiled to WASM via Emscripten.

```sh
npm install --save @jspawn/ghostscript-wasm
```

## Building

### Prerequisites

- Docker (recommended) or
- Emscripten SDK 3.1.60+
- Node.js 18+ for testing (uses built-in node:test)

### Using Docker (Recommended)

The easiest way to build ghostscript-wasm is using Docker:

```bash
# Build the Docker image
docker build -t ghostscript-wasm-builder .

# Run the build inside Docker container
docker run --rm -v $(pwd):/src -w /src ghostscript-wasm-builder ./build.sh

# The built files will be in the dist/ directory
ls dist/
```

### Manual Build

If you prefer to build manually with Emscripten installed locally:

```bash
# Initialize submodules
git submodule update --init --recursive

# Install Node.js dependencies
npm install

# Run the build script
./build.sh
```

#### Build Requirements

- **Emscripten**: Version 3.1.60 or later
- **System packages**: `autotools-dev`, `automake`, `libtool`
- **binaryen**: For WASM optimization (included in Docker image)

## Testing

After building, run the test suite:

```bash
npm test
```

The tests validate that:
- EPS files can be converted to PNG
- Error handling works correctly
- The WASM module loads and executes properly

## Examples

See the `tests` directory for examples of how to use the compiled ghostscript WASM module.

## Build Output

The build process creates several files in the `dist/` directory:
- `gs.js` - Main JavaScript wrapper
- `gs.wasm` - WebAssembly binary
- `gs.mjs` - ES6 module wrapper

## Continuous Integration

This project includes GitHub Actions CI that automatically builds and tests the WASM artifacts on every push.
