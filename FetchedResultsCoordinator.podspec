Pod::Spec.new do |s|
  s.name             = "FetchedResultsCoordinator"
  s.version          = "0.1.0"
  s.summary          = "Wrapper around boilerplate code needed to hook up a
  NSFetchedResultsController to UITableViews and UICollectionViews."

  s.description      = <<-DESC
  Implements NSFetchedResultsControllerDelegate boilerplate code that
  updates a table or collection view with managed object changes observed by
  a NSFetchedResultsController.  Also provides simple data source
  implementations for both table views (UITableViewDataSource) and
  collection views (UICollectionViewDataSource) backed by a
  NSFetchedResultsController.
                       DESC

  s.homepage         = "https://github.com/mcarter6061/FetchedResultsCoordinator"
  s.license          = 'MIT'
  s.author           = { "Mark Carter" => "mark@deeperdigital.co.uk" }
  s.source           = { :git => "https://github.com/mcarter6061/FetchedResultsCoordinator.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mjark'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'UIKit', 'CoreData'
end
