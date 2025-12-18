#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#import "../consts.typ": *


#let equation-code = "equation-code"

#let code-numering(_) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  // set text(top-edge: "cap-height", bottom-edge: "baseline")
  let type-num = counter(equation-code + chapter-num).display()
  let num-str = "(" + numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1) + ")"
  num-str
}

#let code-numering-step() = {
  let chapter-num = counter(heading.where(level: 1)).display()
  counter(equation-code + chapter-num).step()
}

#let set-equation(body) = {
  set math.equation(
    numbering: code-numering, 
    supplement: [式],
    number-align: horizon,
  )

  show math.equation.where(block: true): it => {
    let formatting = math.equation(numbering: none, it.body)
    set text(size: font-size.小四)

    let eqNumbering = none
    if it.has("label"){
      let eqCounter = counter(math.equation).at(it.location())
      code-numering-step()
      eqNumbering = numbering(it.numbering, ..eqCounter)
    }
    
    // 设置公式内部行距 (防止切断积分号)
    set par(leading: 单倍行距)

    block(
      width: 100%, 
      inset: 0pt, // 确保没有额外内边距
      above: above-leading-space(space: 6pt, word-space: 单倍行距),
      below: below-leading-space(6pt),
      grid(
          columns: (1fr, auto, 1fr),
          [],
          align(horizon)[
              #formatting
            ],
          align(right + horizon)[#eqNumbering],
        )
    )
  }
  body
}
