#import "../consts.typ": *
#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#let figure-kind-code = "figure-kind-code"
#let figure-kind-pic = "figure-kind-pic"
#let figure-kind-tbl = "figure-kind-tbl"

#let figure-env-set(body) = {
  set block(breakable: true)

  show figure.where(kind: figure-kind-tbl): set figure.caption(position: top)
  show figure.caption: set text(size: font-size.五号)
  // 利用 box 的自动伸缩来实现
  // 只有一行的时候居中
  // 多行左对齐
   show figure: set figure(gap: 6pt)
  // 显示的前后边距
  let figure-body(it) = {
    set par(leading: above-leading-space())
    it
  }
  // show figure: set block(above: 2em, below: 2em)
  // 图的整体间距：段前 6pt (段后由 caption 控制)
  show figure.where(kind: figure-kind-pic): set block(above: above-leading-space(space: 6pt, word-space: 单倍行距), below: below-leading-space(12pt))
  show figure.where(kind: figure-kind-tbl): set block(above: above-leading-space(space: 12pt, word-space: 单倍行距), below: below-leading-space(6pt))
  // figure 计数器自增函数
  // 图1-1 后变成 图1-2
  let count-step(kind) = {
    let chapter-num = counter(heading.where(level: 1)).get().first()
    counter(kind + str(chapter-num)).step()
  }

  show figure.caption: it => {
    let indent-width = measure(h(4em)).width
    let size = measure(it.body)
    layout(bounds => {
      let full-caption = if it.numbering != none {
              [#it.supplement#it.counter.display(it.numbering)#h(0.5em)#it.body]
            } else {
              it.body
            }
      if size.width > bounds.width - indent-width * 2 {
        set par(justify: true, leading: above-leading-space())
        box(
          width: 100%, 
          inset: (x: indent-width), // 左右缩进
          align(left, full-caption)      // 两端对齐基于左对齐基础
        )
      } else {
        set par(leading: above-leading-space())
        set align(center)
        full-caption
      }
    })
  }

  show figure: it => {
    if it.kind == figure-kind-code {
      figure-body(it)
      count-step(figure-kind-code)
    } else if it.kind == figure-kind-pic {
      figure-body(it)
      count-step(figure-kind-pic)
    } else if it.kind == figure-kind-tbl {
      figure-body(it)
      count-step(figure-kind-tbl)
    } else {
      it.body
    }
  }

  body
}

#let tbl-numering(_) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  let type-num = counter(figure-kind-tbl + chapter-num).display()
  numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1)
}

#let pic-numering(_) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  let type-num = counter(figure-kind-pic + chapter-num).display()
  numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1)
}

#let code-numering(_) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  let type-num = counter(figure-kind-code + chapter-num).display()
  numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1)
}

#let table-figure(caption, table, placement: none) = {
  figure(table, caption: caption, supplement: [表], numbering: tbl-numering, kind: figure-kind-tbl, placement: placement)
}

#let code-figure(caption, code, placement: none) = {
  figure(code, caption: caption, supplement: [代码], numbering: code-numering, kind: figure-kind-code, placement: placement)
}

#let picture-figure(caption, picture, placement: none) = {
  figure(picture, caption: caption, supplement: [图], numbering: pic-numering, kind: figure-kind-pic, placement: placement)
}

