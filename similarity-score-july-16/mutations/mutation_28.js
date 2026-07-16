function opt() {
  let res;
  for (a = 0; a < 1; a++) {
    for (let i = -0.0; i < 1; i++) {
      res = Math.abs(Math.min(-1, i), -0); 
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());