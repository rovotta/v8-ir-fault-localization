function opt() {
  let res;
  for (a = 1; a <= 1; a++) { // Node 5: Changed 0 to 1
    for (let i = +0.0; i < 1; i++) { // Node 30: Changed unary - to unary +
      res += Object.is(Math.max(-1, i), -0); // Node 20: Changed = to +=
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());