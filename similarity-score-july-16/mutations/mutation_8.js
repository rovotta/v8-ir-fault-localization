function opt() {
  let res;
  for (b = 0; b < 1; b++) {
    for (let i = +0.0; i < 1; i++) {
      res = Object.is(Math.min(-1, i), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());