const test = require("node:test");
const assert = require("node:assert");
const path = require("path");
const fs = require("fs/promises");
const Module = require("../dist/gs");

// Group related tests using a top-level test with subtests
test("ghostscript-wasm: all", async (t) => {
  // setup
  await fs.mkdir(path.join(__dirname, "out"), { recursive: true });

  await t.test("should render eps to png", async () => {
    const exitStatus = await callMain([
      "-q",
      "-dSAFER",
      "-dBATCH",
      "-dNOPAUSE",
      "-sDEVICE=png16m",
      "-dGraphicsAlphaBits=4",
      "-sOutputFile=out/tiger.png",
      "assets/tiger.eps",
    ]);
    assert.equal(exitStatus, 0);
  });

  // Ensure this doesn't call `process.exit`
  await t.test("should exit properly on error", async () => {
    const prevExitCode = process.exitCode;
    const exitStatus = await callMain(["unknown-subcommand"]);
    assert.equal(exitStatus, 1);
    // Some Emscripten builds set process.exitCode; restore it so the harness doesn't fail.
    process.exitCode = prevExitCode ?? 0;
  });
});

async function callMain(args) {
  const mod = await Module();
  const working = "/working";
  mod.FS.mkdir(working);
  mod.FS.mount(mod.NODEFS, { root: __dirname }, working);
  mod.FS.chdir(working);
  return mod.callMain(args);
}
