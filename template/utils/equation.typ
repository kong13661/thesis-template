#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#import "../consts.typ": *
#import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, fmt-body

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

#let theorem-supplement = text(font: "Heiti SC")[定理]
#let proof-supplement = text(font: "Heiti SC")[证明]

#let numbering-theorem(step: false, ref: none) = {
  let n = counter(heading.where(level: 1)).get().first()
  let thm-counter = counter("_thm" + str(n))
  if step {
    counter("_thm" + str(n)).step()
  }
  let count
  if ref == none {
    count = counter("_thm" + str(n)).get().first() + 1
  } else {
    count = counter("_thm" + str(n)).at(ref).first() + 1
  }
  let num = numbering("1", n) + "." + str(count)
  num
}

#let new-fmt-body(body, solution) = {[
  #let body-content = body
  #if body.has("children") and body.children.first() == [#parbreak()] {
    // 3. 切片：跳过第 0 个，取从第 1 个开始的所有元素，然后 join 重新拼接成 content
    body-content = body.children.slice(1).join()
  }
 #fmt-body(body-content, solution)
 #parbreak()
 ]}

#let theorem = theorem.with(
  fmt-prefix: (s, n, t) => {
  let num = numbering-theorem(step: true)
  text[#s#num]
  if t!= none {
  h(2pt)
  }
  h(1em)
  },
  fmt-body: new-fmt-body,
  supplement: theorem-supplement,
)

#let proof = proof.with(
  fmt-prefix: (s, n, t) => {
    {
      if t != none {
        let num = numbering-theorem(step: false, ref: t.target)
        t = [#h(2em)#theorem-supplement#num]
      }
      
      if t != none [#t]
      s
      if n != none [ #n]
      h(1em)
  }
  },
  fmt-suffix: () => [#h(1fr)$qed$],
  fmt-body: new-fmt-body,
  supplement: proof-supplement,
)

#let set-theoretic(body) = {
  show ref: theoretic.show-ref
  body
}