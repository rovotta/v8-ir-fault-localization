import openai
import os

OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
client = openai.OpenAI(api_key=OPENAI_API_KEY)

SYSTEM_PROMPT = """Generate a random variant of the given proof-of-concept test program that triggers a bug in a JIT compiler

The program variant must do the following:
    1. Keep function name as opt
    2. Keep these four lines exactly as they are:
        %PrepareFunctionForOptimization(opt);
        console.log(opt());
        %OptimizeFunctionOnNextCall(opt);
        console.log(opt());
   3. Mutated program must be in valid JavaScript that can run in d8
   4. output only the raw JavaScript code

The program variant must NOT do the following:
    1. add comments to output lines that are changed with // 
    2. change the overall structure of the function
    3. add an explanation
    4. add a markdown file or any other files
    5. add any backticks or any other visual aids 

The following are valid mutations:
    1. inserting an if statement 
    2. inserting a for loop statement
    3. inserting a while loop statement 
    4. inserting a function call
    5. inserting a goto statement
    6. inserting a qualifier (examples: volatile, const, restrict)
    7. removing a qualifier (examples: volatile, const, restrict)
    8. inserting a modifier (examples: long, short, signed or unsigned)
    9. removing a modifier (examples: long, short, signed or unsigned)
    10. replacing a constant with another valid constant
    11. replacing a binary operator with another valid binary operator
    12. removing a unary operator on the variables
    13. replacing a unary operator on the variables
    14. replacing a variable with another valid variable

there is no limit to how many mutations can be applied. 
mutations must be as similar as possible to the given proof-of-concept test case.
random mutations must be as diverse from one another as possible."""

def read_poc(path):
    with open(path) as f:
        return f.read()

def generate_mutation(original_code):
    response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"Generate one random mutation of this program:\n\n{original_code}"}
        ],
        temperature=1.0
    )
    return response.choices[0].message.content.strip()

def get_mutation(path="minimised-NumberMax.js"):
    return generate_mutation(read_poc(path))
