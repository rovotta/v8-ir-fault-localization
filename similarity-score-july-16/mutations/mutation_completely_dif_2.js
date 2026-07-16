function opt() {
  let s = "javascript";
  let r = "";
  for (let k = 0; k < s.length; k++) {
    r = s.charAt(k) + r;              // build the reversal
  }
  return r;                          // "tpircsavaj"
}

%PrepareFunctionForOptimization(opt);
print(opt());
%OptimizeFunctionOnNextCall(opt);
print(opt());
