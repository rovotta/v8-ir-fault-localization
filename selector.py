import subprocess

D8_PATH = "/opt/v8_350e0f7997f/v8/out/x64.release/d8"

def run_program(js_code):
    temp_file = "temp_mutation.js"
    with open(temp_file, 'w') as f:
        f.write(js_code)

    try:
        result = subprocess.run(
            [D8_PATH, "--allow-natives-syntax", temp_file],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.stdout.strip(), result.returncode

    except subprocess.TimeoutExpired:
        return None, -1

def check_passing(output):
    if output is None:
        return False
    lines = output.strip().split('\n')
    if len(lines) != 2:
        return False
    return lines[0] == lines[1]

def select(js_code):
    output, returncode = run_program(js_code)
    if returncode != 0:
        return False, output
    return check_passing(output), output


if __name__ == '__main__':
    # test with the failing poc: should return False
    with open("minimised-NumberMax.js") as f:
        failing_code = f.read()
    passed, output = select(failing_code)
    print(f"Failing POC - passed?: {passed}, output: {output!r}")

    # test with the passing poc: should return True
    with open("minimised-NumberMax-modified.js") as f:
        passing_code = f.read()
    passed, output = select(passing_code)
    print(f"Passing POC - passed?: {passed}, output: {output!r}")
