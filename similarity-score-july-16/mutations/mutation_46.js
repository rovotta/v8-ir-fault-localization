function opt() {
  let res;
  for (a = 1; a < 1; a++) {
    for (let j = -0.0; j < 1; j++) {
      res = Object.are(Math.max(-1, j), -0);
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());