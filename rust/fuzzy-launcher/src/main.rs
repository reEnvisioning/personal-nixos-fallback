use serde_json::Value;
use std::env;
use std::fs;
use std::io;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut cache_path = String::new();
    let mut key = String::from("name");
    let mut limit: usize = 15;
    let mut threshold: i64 = -10000;
    let mut query = String::new();

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--cache" if i + 1 < args.len() => {
                i += 1;
                cache_path = args[i].clone();
            }
            "--key" if i + 1 < args.len() => {
                i += 1;
                key = args[i].clone();
            }
            "--limit" if i + 1 < args.len() => {
                i += 1;
                limit = args[i].parse().unwrap_or(15);
            }
            "--threshold" if i + 1 < args.len() => {
                i += 1;
                threshold = args[i].parse().unwrap_or(-10000);
            }
            _ if query.is_empty() => query = args[i].clone(),
            _ => {}
        }
        i += 1;
    }

    if cache_path.is_empty() || query.is_empty() {
        eprintln!("Usage: fuzzy-launcher --cache <path> [--key <field>] [--limit <n>] [--threshold <n>] <query>");
        std::process::exit(1);
    }

    let data = match fs::read_to_string(&cache_path) {
        Ok(d) => d,
        Err(e) => {
            eprintln!("Warning: cannot read cache '{}': {}", cache_path, e);
            output_results(&[]);
            return;
        }
    };

    let entries: Vec<Value> = match serde_json::from_str(&data) {
        Ok(e) => e,
        Err(e) => {
            eprintln!("Warning: invalid cache JSON: {}", e);
            output_results(&[]);
            return;
        }
    };

    let top = fuzzy_filter(&entries, &key, &query, limit, threshold);
    output_results(&top);
}

fn fuzzy_filter(entries: &[Value], key: &str, query: &str, limit: usize, threshold: i64) -> Vec<Value> {
    let mut scored: Vec<(i64, &Value)> = entries
        .iter()
        .filter_map(|entry| {
            let target = entry.get(key).and_then(|v| v.as_str()).unwrap_or("");
            fuzzy_score(query, target).map(|score| (score, entry))
        })
        .filter(|(score, _)| *score >= threshold)
        .collect();

    scored.sort_by(|a, b| b.0.cmp(&a.0));
    scored.truncate(limit);
    scored.into_iter().map(|(_, entry)| entry.clone()).collect()
}

fn fuzzy_score(query: &str, target: &str) -> Option<i64> {
    if target.is_empty() {
        return None;
    }

    let query = query.to_lowercase();
    let target = target.to_lowercase();

    if query.is_empty() {
        return Some(0);
    }
    if query.len() > target.len() {
        return None;
    }

    if target.starts_with(&query) {
        let mut score: i64 = 1000;
        score += (query.len() as i64) * 50;
        if target == query {
            score += 500;
        }
        return Some(score);
    }

    let qchars: Vec<char> = query.chars().collect();
    let tchars: Vec<char> = target.chars().collect();

    let mut score: i64 = 0;
    let mut qi = 0;
    let mut prev_ti: Option<usize> = None;

    for (ti, &tc) in tchars.iter().enumerate() {
        if qi < qchars.len() && tc == qchars[qi] {
            if let Some(prev) = prev_ti {
                let gap = ti - prev - 1;
                if gap == 0 {
                    score += 15;
                } else {
                    score = score.saturating_sub(gap as i64);
                    if prev > 0 && (tchars[prev] == ' ' || tchars[prev] == '-' || tchars[prev] == '_') {
                        score += 5;
                    }
                }
            } else {
                score += if ti == 0 {
                    10
                } else if tchars[ti - 1] == ' '
                    || tchars[ti - 1] == '-'
                    || tchars[ti - 1] == '_'
                {
                    8
                } else {
                    1
                };
            }
            prev_ti = Some(ti);
            qi += 1;
        }
    }

    if qi == qchars.len() {
        Some(score)
    } else {
        None
    }
}

fn output_results(results: &[Value]) {
    serde_json::to_writer(io::stdout(), results).unwrap();
    println!();
}
