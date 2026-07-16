function opt() {
  let res;
  for (b = 0; b < 1; b++) {
    for (let j = -0.0; j < 1; j++) {
      res = Object.is(Math.min(-1, j), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());