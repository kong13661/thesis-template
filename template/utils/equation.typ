#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#import "../consts.typ": *
#import "@preview/theoretic:0.2.0" as theoretic: theorem, proof, fmt-body

#let equation-code = "equation-code"

#let equation-numering(nums, element: none) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  let loc = if element != none { element.location() } else { here() }
  let type-num = counter(equation-code + chapter-num).at(loc).first()
  let num-str = "(" + numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1) + ")"
  num-str
}

#let equation-numering-step() = {
  let chapter-num = counter(heading.where(level: 1)).display()
  counter(equation-code + chapter-num).step()
}

#let set-equation(body) = {
  set math.equation(
    numbering: equation-numering, 
    supplement: [式],
    number-align: horizon,
  )

  show math.equation.where(block: true): it => {
    let formatting = math.equation(numbering: none, it.body)
    set text(size: font-size.小四)

    let eqNumbering = none
    if it.has("label"){
      let eqCounter = counter(math.equation).at(it.location())
      equation-numering-step()
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
#let lemma-supplement = text(font: "Heiti SC")[引理]
#let proof-supplement = text(font: "Heiti SC")[证明]

#let numbering-theorem(kind: none, step: false, ref: none) = {
  let n = counter(heading.where(level: 1)).get().first()
  let thm-counter = counter("_thm" + str(n))
  let name-counter = if kind != none { kind + str(n) } else { "_thm" + str(n)}
  if step {
    counter(name-counter).step()
  }
  let loc = if ref != none { ref } else { here() }
  let count = counter(name-counter).at(loc).first() + 1
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
  let num = numbering-theorem(kind: s.child.text, step: true)
  text[#s#num]
  if t!= none {
  h(2pt)
  }
  h(0.5em)
  },
  fmt-body: new-fmt-body,
  supplement: theorem-supplement,
  kind: "theorem",
  toctitle: false,
)

#let lemma = theorem.with(
  supplement: lemma-supplement,
  kind: "lemma"
)

#let proof = proof.with(
  fmt-prefix: (s, n, t) => {
    {
      if t != none {
        let ele = query(t.target)
        let num = numbering-theorem(kind: ele.first().value.supplement.child.text, 
            step: false, ref: t.target)
        t = link(ele.first().location())[#ele.first().value.supplement#num]
      }
      
      if t != none [#t]
      s
      if n != none [ #n]
      h(0.5em)
  }
  },
  fmt-suffix: () => [#h(1fr)$qed$],
  fmt-body: new-fmt-body,
  supplement: proof-supplement,
)

#let show-ref(
  it,
) = {
  let el = it.element
  if (
    el != none
      and el.func() == metadata
      and type(el.value) == dictionary
      and el.value.at("theorem-kind", default: none) != none
  ) {
    let val = el.value
    let ele = query(it.target)
    let num = numbering-theorem(kind: ele.first().value.supplement.child.text, 
            step: false, ref: it.target)
    [#ele.first().value.supplement#num]
  } else {
    // Other references as usual.
    it
  }
}

#let set-theoretic(body) = {
  show ref: show-ref
  body
}