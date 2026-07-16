function opt() {
  let result;
  for (let x = 2; x >= 1; x--) {
    for (let b = 2; b >= 1; b--) {
      result = Object.is(Math.max(-1, b), -1);
    }
  }
  return result;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());

