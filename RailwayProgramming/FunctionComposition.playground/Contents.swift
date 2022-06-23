import Overture

func incr(_ x: Int) -> Int {
  return x + 1
}

incr(2) // 3

func square(_ x: Int) -> Int {
  return x * x
}

square(2) // 4

square(incr(2)) // 9

extension Int {
  func incr() -> Int {
    return self + 1
  }

  func square() -> Int {
    return self * self
  }
}

2.incr() // 3

2.incr().square() // 9

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
  return f(a)
}

2 |> incr // 3
with(2, incr) // Overture

2 |> incr |> square
with(with(2, incr), square) // Overture

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>><A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

incr >>> square
pipe(incr, square)  // Overture

square >>> incr
pipe(square, incr)  // Overture

(square >>> incr)(3) // 10
pipe(square, incr)(3)  // Overture

2 |> incr >>> square
with(2, pipe(incr, square)) //Overture

2 |> incr >>> square >>> String.init // "9"
with(2, pipe(incr, square, String.init))


[1, 2, 3].map { ($0 + 1) * ($0 + 1) } // [4, 9, 16]

[1, 2, 3]
  .map(incr)
  .map(square)

[1, 2, 3].map(incr >>> square) // [4, 9, 16]

