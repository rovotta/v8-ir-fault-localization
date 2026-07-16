function opt() {
  let res;
  for (a = 0; a < 1; a++) {
    for (let i = -0.0; i <= 1; i++) {  // Node 11 mutation
      res = Object.is(Math.min(-1, i), -0); // Node 26 mutation
    }
  }
  return res;
}

%PrepareFunctionForOptimization(opt);
console.log(opt());
%OptimizeFunctionOnNextCall(opt);
console.log(opt());