function opt() {
  let newRes;
  for (a = 0; a <= 1; a++) {
    for (let i = +0.0; i < 1; i++) {
      newRes = Object.is(Math.max(-1, i), -0);
    }
  }
  return newRes;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());