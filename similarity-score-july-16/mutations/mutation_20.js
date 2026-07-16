function mutatedOpt() {
  let res;
  for (a = 0; a < 0; a++) {
    for (let i = -0.0; i < 1; i++) {
      res = Object.is(Math.max(-1, i), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(mutatedOpt);
console.log(mutatedOpt());
%OptimizeFunctionOnNextCall(mutatedOpt);
console.log(mutatedOpt());