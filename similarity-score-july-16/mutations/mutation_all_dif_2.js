function opt() {
  let out;                              // 1  res -> out
  for (b = 5; b > 3; b--) {             // 4 a->b, 5 0->5, 6 <->>, 7 a->b, 8 1->3, 9 ++->--, 10 a->b
    for (let j = +4.0; j >= 2; j--) {   // 12 i->j, 13 -->+, 14 0.0->4.0, 15 <->>=, 16 i->j, 17 1->2, 18 ++->--, 19 i->j
      out = Object.is(Math.min(+2, j), +4);  // 21 res->out, 29 max->min, 30 -->+, 31 1->2, 32 i->j, 33 -->+, 34 0->4
    }
  }
  return out;                           // 35 res -> out
}

%PrepareFunctionForOptimization(opt);
print(opt());
%OptimizeFunctionOnNextCall(opt);
print(opt());
