#import "info.typ": *
#import "font.typ": *
#import "word_spacing.typ": above-leading-space, below-leading-space

#let common-set(info, body) = {
  set par(first-line-indent: (amount: 2em, all: true), justify: true)
  set text(region: "cn", lang: "zh", font: info.at(info-keys-private.字体).宋体, size: font-size.小四)
  // set text(top-edge: "ascender", bottom-edge: "descender")
  set text(top-edge: 0.8em, bottom-edge: -0.2em)
  set strong(delta: info.at(info-keys.加粗粗度))
  body
}

#let commen-space-set(body) = {
  set par(first-line-indent: (amount: 2em, all: true), justify: true, leading: above-leading-space(), spacing: above-leading-space())
  body
}

#let 其他-space-set(body) = {
  set par(leading: 1em, spacing: 1em, justify: true)
  body
}