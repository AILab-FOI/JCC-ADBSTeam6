export function choice<T>(ls: T[]): T {
    let len = ls.length;
    return ls[Math.floor(len * Math.random())]
}

export function choiceN<T>(N: number, ls: T[], avoidSame: boolean = true): T[] {
    if (avoidSame && N > ls.length) throw new Error("Can fetch more element, uniquely, that there is in the passed array.");

    let ret: T[] = []

    for (let _ = 0; _ < N; _++) {
        let ele = choice(ls)
        while (ret.includes(ele)) {
            ele = choice(ls)
        }

        ret.push(ele)
    }

    return ret;
}