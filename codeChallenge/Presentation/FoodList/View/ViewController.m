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
@property (nonatomic, readwrite) NSArray *loadedPhotos;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [self loadFlickrPhotos];
    UINib *cellNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"CustomCell"];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            self.photos = self.loadedPhotos;
            [self reload];
            break;
        case 1:
            self.photos = [self sortPhotos:NO];
            [self reload];
            break;
        case 2:
            self.photos = [self sortPhotos:YES];
            [self reload];
            break;
        default:
            break;
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    NSString *urlPhotoString = [[self.photos objectAtIndex:indexPath.row] objectForKey:@"url_t"];
    NSURL *urlPhoto = [NSURL URLWithString:urlPhotoString];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:urlPhoto];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    detailController.image = image;
    detailController.titleText = [[self.photos objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *dateString = [[self.photos objectAtIndex:indexPath.row] objectForKey:@"datetaken"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    detailController.dateText = date;
    detailController.descriptionText = [[[self.photos objectAtIndex:indexPath.row] objectForKey:@"description"] objectForKey:@"_content"];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)reload {
     [self.tableView reloadData];
}

- (NSArray *)sortPhotos:(BOOL)isAscending {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetaken" ascending:isAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    return [self.photos sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)loadFlickrPhotos {
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=15&format=json&nojsoncallback=1&extras=date_taken,description,title,tags,url_t", FlickrAPIKey, @"cooking"];
    NSURL *URL = [NSURL URLWithString:urlString];
    NetworkProcessor *networkProcessor = [[NetworkProcessor alloc]initWithUrl:URL];
    [networkProcessor downloadJSONFromURLOnSucess:^(NSDictionary * result) {
        self.photos = [[result objectForKey:@"photos"] objectForKey:@"photo"];
        self.loadedPhotos = self.photos;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reload];
        });
    } onError:^(NSError * error) {
        switch (error.code) {
            case 0:
                [self presentNoConnectionError];
                break;
            case 1:
                [self presentTimeOutError];
                break;
            default:
                [self presentGenericError];
                break;
        }
    }];
}

- (void)presentGenericError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong." message:@"Sorry, it's not you, it's us! Please try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadFlickrPhotos];
        }]
    ];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentTimeOutError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oh no!" message:@"This is taking a little longer than usual." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadFlickrPhotos];
        }]
    ];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentNoConnectionError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oh no!" message:@"Could not find a network connection. Connect to the internet to try again." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadFlickrPhotos];
        }]
    ];
    [alert addAction: [UIAlertAction actionWithTitle:@"Check connection" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]
    ];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
