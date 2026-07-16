function opt() {
  let res;
  for (a = 0; a < 1; a++) {
    for (let i = -0.0; i < 1; i++) {
      res = Object.is(Math.max(-1, a), -0); // Note the change of 'i' to 'a' here
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());