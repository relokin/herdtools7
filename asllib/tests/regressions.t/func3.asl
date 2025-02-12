getter f1() => integer
begin
  return 3;
end;

setter f1() = v : integer
begin
  assert v == 3;
end;

getter f1b() => integer
begin
  return 4;
end;

setter f1b() = v : integer
begin
  assert v == 4;
end;

getter f2(x:integer) => integer
begin
  return f1b() + x;
end;

setter f2(x:integer) = v : integer
begin
  f1b() = 4 * (v - x);
end;

getter f3(x:integer) => integer
begin
  return 0;
end;

setter f3(x:integer) = v : integer
begin
  assert x == 12;
  assert v == 13;
end;

func main() => integer
begin
  f1() = f1();
  // f1 = f1; // Illegal because f1 is not an empty setter/getter
  f1b() = f1b();
  let a = f1();
  assert a == 3;
  assert f1() == 3;
  let b = f1();
  assert b == 3;
  assert 3 == f1();
  let c = f2(4);
  assert c == 8;

  f2(5) = 6;
  f3(12) = 13;

  return 0;
end;

// RUN: archex.sh --eval=':set asl=1.0' --eval=':set +syntax:aslv1_colon_colon' --eval=':load %s' --eval='assert main() == 0;' | FileCheck %s

