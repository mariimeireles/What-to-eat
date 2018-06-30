//
//  ViewController.m
//  codeChallenge
//
//  Created by Nano Suarez on 18/04/2018.
//  Copyright © 2018 Fernando Suárez. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "codeChallenge-Swift.h"

NSString *const FlickrAPIKey = @"2ed35a9f4fda03bc96e73dbd03602780";

@interface ViewController ()
@property (nonatomic, readwrite) NSArray *photos;

@end

@implementation ViewController

- (void)viewDidLoad {
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=15&format=json&nojsoncallback=1&extras=date_taken,description,title,tags,url_t", FlickrAPIKey, @"cooking"];
    NSURL *URL = [NSURL URLWithString:urlString];
    NetworkProcessor *networkProcessor = [[NetworkProcessor alloc]initWithUrl:URL];
    [networkProcessor downloadJSONFromURL:^(NSDictionary * result) {
        self.photos = [[result objectForKey:@"photos"] objectForKey:@"photo"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reload];
        });
    }];
    
    UINib *cellNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"CustomCell"];
}


//TableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CustomCell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.imageTitleCell.text = [[self.photos objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.imageSubtitleCell.text = [[[self.photos objectAtIndex:indexPath.row] objectForKey:@"description"] objectForKey:@"_content"];
    NSString *urlPhotoString = [[self.photos objectAtIndex:indexPath.row] objectForKey:@"url_t"];
    NSURL *urlPhoto = [NSURL URLWithString:urlPhotoString];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:urlPhoto];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    cell.imageCell.image = image;

    return cell;
}

- (void)reload {
     [self.tableView reloadData];
}

@end
