//
//  ViewController.swift
//  Zoom
//
//  Created by muukii on 2016/11/25.
//  Copyright © 2016 muukii. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxOrigami

class ViewController: UIViewController {

  @IBOutlet weak var card: UIView!
  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let pan = UIPanGestureRecognizer()

    view.addGestureRecognizer(pan)

    let drag = pan.rx.event.map { [unowned self] gesture -> CGFloat in

      let point = gesture.translation(in: self.card)
      return point.y
      }
    .debug()

    let distance: CGFloat = -100

    let progress = drag
      .progress(start: Observable<CGFloat>.just(0), end: Observable<CGFloat>.just(distance))
      .clip(min: .just(0), max: .just(1))
      .debug()
      .shareReplay(1)

    let animation = CABasicAnimation(keyPath: "transform")
    animation.fromValue = CATransform3DIdentity
    animation.toValue = CATransform3DMakeAffineTransform(
      CGAffineTransform(
        scaleX: view.bounds.width / card.bounds.width,
        y: view.bounds.height / card.bounds.height
        )
        .concatenating(CGAffineTransform(translationX: 0, y: distance/2)))
    animation.duration = 1

    card.layer.speed = 0
    card.layer.add(animation, forKey: "transitionAnimation")

    progress.bindNext { [unowned self] progress in

      self.card.layer.timeOffset = progress.native
      }
      .addDisposableTo(disposeBag)
  }

}

