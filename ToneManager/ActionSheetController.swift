import UIKit
import XLActionController

open class ActionSheetController: ActionController<ActionSheetCell, ActionData, UICollectionReusableView, Void, UICollectionReusableView, Void> {
    
    static let bottomPadding: CGFloat = 20.0
    
    lazy var hideBottomSpaceView: UIView = {
        let width = collectionView.bounds.width - safeAreaInsets.left - safeAreaInsets.right
        let height = contentHeight + ActionSheetController.bottomPadding + safeAreaInsets.bottom
        let hideBottomSpaceView = UIView(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        hideBottomSpaceView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        hideBottomSpaceView.backgroundColor = .white
        return hideBottomSpaceView
    }()
    
    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        collectionViewLayout.minimumLineSpacing = -0.5
        
        settings.behavior.hideNavigationBarOnShow = false
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.5
        settings.animation.dismiss.offset = 30
        settings.animation.dismiss.options = .curveEaseIn
        
        cellSpec = .nibFile(nibName: "ActionSheetCell", bundle: nil, height: { _  in 46 })
        
        onConfigureCellForAction = { cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            cell.alpha = action.enabled ? 1.0 : 0.5
            cell.actionTitleLabel?.textColor = action.style == .destructive ? ColorPalette.actionSheetLabelDestructive : ColorPalette.actionSheetLabelDefault
            cell.actionImageView?.tintColor = action.style == .destructive ? ColorPalette.actionSheetLabelDestructive : ColorPalette.actionSheetLabelDefault
        }
    }
  
    required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.clipsToBounds = false
        collectionView.addSubview(hideBottomSpaceView)
        collectionView.sendSubview(toBack: hideBottomSpaceView)
    }
    
    @available(iOS 11, *)
    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        hideBottomSpaceView.frame.size.height = contentHeight + ActionSheetController.bottomPadding + safeAreaInsets.bottom
        hideBottomSpaceView.frame.size.width = collectionView.bounds.width - safeAreaInsets.left - safeAreaInsets.right
    }
}
