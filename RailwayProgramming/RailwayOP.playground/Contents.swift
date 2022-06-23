import UIKit
import Foundation

enum TestError: Error {
    case notFound
}

// MARK: - Adapter functions

func bind<A, B>(_ f: @escaping (A) -> Result<B, Error>) -> (Result<A, Error>) -> Result<B, Error> {
    return { result in
        result.flatMap(f)
    }
}

func pipe<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

func pipe<A, B, C, D>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C, _ h: @escaping (C) -> D) -> (A) -> D {
    return { a in
        h(g(f(a)))
    }
}

func doubleWithError(_ a: Int) -> Result<Int, Error> {
    return .success(a * a)
}

func incrWithError(_ a: Int) -> Result<Int, Error> {
    return .success(a + 1)
}


bind(pipe(doubleWithError, bind(incrWithError)))(.failure(TestError.notFound))

bind(doubleWithError)(.success(2))

pipe(incrWithError, bind(doubleWithError))(2)


// MARK: - Convert one track functions

let normalize = { (input: String) in
    input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
}

func map<A, B>(_ f: @escaping (A) -> B) -> (Result<A, Error>) -> Result<B, Error> {
    return { result in
        result.map(f)
    }
}

map(normalize)(.success("HELLO   "))

// MARK: - Convert dead-end functions

func tee<A>(_ f: @escaping (A) -> Void) -> (Result<A, Error>) -> Result<A, Error> {
    return { result in
        result.map { a in
            f(a)
            return a
        }
    }
}

let email = "litianu.razvan@gmail.COM   "

func validate(email: String) -> Result<String, Error> {
    .success(normalize(email))
}

validate(email: email)

func updateDB(email: String) {
    print("Updating database with \(email)")
}

func sendConfirmation(email: String) -> Result<String, Error> {
    print("Sending confirmation to email with \(email)")
    return .success(email)
}

pipe(validate, tee(updateDB), bind(sendConfirmation))(email)

// MARK: - Functions that throw exceptions

func login(user: String) throws {
    guard !user.isEmpty else { throw TestError.notFound }
}

try login(user: "user")

func toFailure<A>(_ f: @escaping (A) throws -> Void) -> (A) -> Result<A, Error> {
    return { a in
        do {
            try f(a)
            return .success(a)
        } catch {
            return .failure(error)
        }
    }
}

pipe(validate, bind(toFailure(login)))("    AAA")
