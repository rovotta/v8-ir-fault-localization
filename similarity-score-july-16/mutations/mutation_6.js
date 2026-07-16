function opt() {
  let result;
  for (a = 0; a < 1; a++) {
    for (let i = -0.0; i <= 1; i++) {
      result = Object.is(Math.max(+1, i), -0);
    }
  }
  return result;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());