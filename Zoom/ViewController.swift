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

    let progress = drag
      .progress(start: Observable<CGFloat>.just(0), end: Observable<CGFloat>.just(-100))
      .clip(min: .just(0), max: .just(1))
      .debug()
      .shareReplay(1)

    let finalWidthRetio = view.bounds.width / card.bounds.width
    let finalHeightRetio = view.bounds.height / card.bounds.height
    print(finalWidthRetio, finalHeightRetio)

    card.layer.setAffineTransform(CGAffineTransform(scaleX: finalWidthRetio, y: finalHeightRetio))
    let rect = card.layer.frame
    card.layer.transform = CATransform3DIdentity

    print(rect)

    let transform = Observable.zip(
      progress.transition(
        start: Observable<CGFloat>.just(1),
        end: Observable<CGFloat>.just(finalWidthRetio)
      ),
      progress.transition(
        start: Observable<CGFloat>.just(1),
        end: Observable<CGFloat>.just(finalHeightRetio)
      ),
      progress
        .transition(start: Observable<CGFloat>.just(0), end: Observable<CGFloat>.just(-rect.minY))
    ) { $0 }

    transform.bindNext { x, y, ty in

      self.card.layer.setAffineTransform(CGAffineTransform(scaleX: x, y: y).concatenating(CGAffineTransform(translationX: 0, y: ty)))
    }
  }

  @IBOutlet weak var card: UIView!
}

