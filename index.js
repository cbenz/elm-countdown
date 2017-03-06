console.log("salut")

function f1(callback) {
    let delay = 2000 + Math.random() * 3000
    window.setTimeout(function() {
        console.log("delay: ", delay)
        callback()
    }, delay)
}

let functions = [f1, f1, f1]

// f1(function() {
//     console.log("after f1")
// })

function step(functions, callback) {
    if (functions.length === 0) {
        callback()
    } else {
        functions[0](function() {
            step(functions.slice(1), callback)
        })

    }
}

// step(functions, function() {
//     console.log("after step")
// })


function parallel(functions, callback) {
    let count = 0
    function inc() {
        if (count === functions.length - 1) {
            callback()
        } else {
            count++
        }
    }
    functions.forEach(function(fn) {
        fn(inc)
    })
}

// parallel(functions, function() {
//     console.log("after parallel")
// })
