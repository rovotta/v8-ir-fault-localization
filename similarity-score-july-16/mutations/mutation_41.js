function opt() {
  let res;
  for (a = 0; a < 1; a++) {
    for (let j = -0.0; j < 2; j++) {
      res = Object.is(Math.max(-1, j), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());