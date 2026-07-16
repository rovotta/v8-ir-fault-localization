function newOpt() {
  let res;
  for (b = 0; b < 1; b++) {
    for (let i = -0.0; i < 1; i++) {
      res = Math.is(Math.max(-1, i), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(newOpt);
console.log(newOpt());
%OptimizeFunctionOnNextCall(newOpt);
console.log(newOpt());