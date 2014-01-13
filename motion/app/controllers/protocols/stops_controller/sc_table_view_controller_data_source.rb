module SCTableViewControllerDataSource
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    if indexPath.section == 0
      reuseIdentifier = "PlansCell"

      cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) || begin
        UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: reuseIdentifier)
      end

      if indexPath.row == 0
        cell.textLabel.text = "Itinéraire via Plans"
      else
        cell.textLabel.text = "Itinéraire via Google Maps"
      end

      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    else
      line = model.lines[indexPath.section - 1]
      direction = line.directions[indexPath.row]

      reuseIdentifier = "StopCell"

      cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) || begin
        UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: reuseIdentifier)
      end

      cell.textLabel.text = direction.name
      cell.detailTextLabel.text = direction.formattedTimes
    end

    cell
  end

  def numberOfSectionsInTableView(tableView)
    1 + model.lines.size
  end

  def tableView(tableView, numberOfRowsInSection: section)
    if section == 0
      App.shared.canOpenURL(NSURL.URLWithString("comgooglemaps://")) && 2 || 1
    else
      model.lines[section - 1].directions.size
    end
  end
end
