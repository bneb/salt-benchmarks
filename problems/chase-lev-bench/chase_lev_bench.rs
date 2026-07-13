use std::time::Instant;
fn main() {
    let start = Instant::now();
    let mut _sum: i64 = 0;
    for i in 0..1000000 { _sum += i; }
    println!("Chase-lev Rust: {:?}", start.elapsed());
}
