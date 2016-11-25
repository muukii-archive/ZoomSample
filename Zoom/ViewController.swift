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

    let transform = Observable.zip(
      progress.transition(
        start: Observable<CGFloat>.just(1),
        end: Observable<CGFloat>.just(view.bounds.width / card.bounds.width)
      ),
      progress.transition(
        start: Observable<CGFloat>.just(1),
        end: Observable<CGFloat>.just(view.bounds.height / card.bounds.height)
      ),
      progress
        .transition(start: Observable<CGFloat>.just(0), end: Observable<CGFloat>.just(distance/2))
    ) { $0 }

    transform.bindNext { [unowned self] x, y, ty in

      self.card.layer.setAffineTransform(CGAffineTransform(scaleX: x, y: y).concatenating(CGAffineTransform(translationX: 0, y: ty)))
      }
      .addDisposableTo(disposeBag)
  }

}

