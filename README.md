I found a bug in the UITableView under iOS7. This little piece of code will produce a memory leak, when I call the method 'reloadSections' from UITableView. When this happens, the Table-Object will retained from anywhere in the library. How you can check this?

1. Open the App
2. When you click on 'Count' you can see, how many cells will be allocated.
3. Wait a minute, so that a section is reloaded. The count of cell will be increased, but thats not a problem.
4. Click on a cell, so that a new controller is shown. Wait a moment so that the cell will be reloaded. More cells will be allocated, but thats not a problem at all.
5. Go back and then take a look at the count. It's not going down, but the cell should be deallocated!

If you go back before the cells are reloaded, everything is still fine. If you run the steps under iOS6, everything is still fine. If you take a deeper look in instruments for the second table, you see something like this:

>
  0	Malloc	+1	1	00:08.857.342	AppleBugTest	-[ViewController viewDidLoad]
  1	Retain	+1	2	00:08.857.753	AppleBugTest	-[ViewController setTableView:]
  2	Release	-1	1	00:08.857.754	AppleBugTest	-[ViewController viewDidLoad]
  3	Retain	+1	2	00:08.857.756	AppleBugTest	-[ViewController viewDidLoad]
  4	Release	-1	1	00:08.857.818	AppleBugTest	-[ViewController viewDidLoad]
  5	Retain	+1	2	00:08.857.820	AppleBugTest	-[ViewController viewDidLoad]
  6	Release	-1	1	00:08.858.046	AppleBugTest	-[ViewController viewDidLoad]
  7	Retain	+1	2	00:08.858.229	AppleBugTest	-[ViewController viewDidLoad]
  8	Retain	+1	3	00:08.858.271	UIKit	-[UIView(Internal) _addSubview:positioned:relativeTo:]
  9	Release	-1	2	00:08.858.314	AppleBugTest	-[ViewController viewDidLoad]
  10	Retain	+1	3	00:08.858.391	AppleBugTest	-[ViewController viewWillAppear:]
  11	Retain	+1	4	00:08.858.483	Foundation	-[NSConcreteNotification initWithName:object:userInfo:]
  12	Release	-1	3	00:08.858.599	AppleBugTest	-[ViewController viewWillAppear:]
  13	Retain	+1	4	00:08.858.963	UIKit	-[UIView(Hierarchy) subviews]
   	Retain/Release (8)		 	00:08.876.182	QuartzCore	-[CALayer layoutSublayers]
   	Retain/Release (18)		 	00:08.876.328	AppleBugTest	-[ViewController tableView:cellForRowAtIndexPath:]
  36	Release	-1	3	00:08.893.061	Foundation	-[NSConcreteNotification dealloc]
  37	Retain	+1	4	00:11.858.958	AppleBugTest	__33-[ViewController viewWillAppear:]_block_invoke
  38	Retain	+1	5	00:11.859.533	UIKit	-[_UITableViewUpdateSupport initWithTableView:updateItems:oldRowData:newRowData:oldRowRange:newRowRange:context:]
   	Retain/Release (8)		 	00:11.859.948	AppleBugTest	-[ViewController tableView:cellForRowAtIndexPath:]
  47	Retain	+1	6	00:11.865.044	libsystem_sim_blocks.dylib	_Block_object_assign
   	Retain (15)	+15	 	00:11.865.113	libsystem_sim_blocks.dylib	_Block_object_assign
  63	Release	-1	20	00:11.868.793	UIKit	-[_UITableViewUpdateSupport dealloc]
  64	Release	-1	19	00:11.868.894	AppleBugTest	__33-[ViewController viewWillAppear:]_block_invoke
  69	Release	-1	18	00:13.127.727	UIKit	-[UIViewController dealloc]
  70	Release	-1	17	00:13.127.985	UIKit	-[UIView(Internal) _invalidateSubviewCache]
  71	Release	-1	16	00:13.128.033	UIKit	-[UIView(Hierarchy) removeFromSuperview]

The row after #47: Here we have 15 retains! That does not look very good.