import Foundation
import UIKit


// Bit of a hack so the table view creates subtitle style cells.  UITableViewController will create .Default style cells, so here we are overriding the init and swapping style .Subtitle

public class SubtitleCell: UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init( style: .Subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = [#Color(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)#]
        detailTextLabel?.textColor = [#Color(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)#]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
