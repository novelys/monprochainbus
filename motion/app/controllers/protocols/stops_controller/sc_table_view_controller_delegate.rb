module SCTableViewControllerDelegate
  def tableView(tableView, viewForHeaderInSection:section)
    if section > 0
      line = model.lines[section - 1]
      view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 44, 44.0))

      headerLabel = UILabel.alloc.initWithFrame(CGRectMake(10, 0, 46, 28))
      headerLabel.backgroundColor = line.color
      headerLabel.attributedText = line.attributedName
      headerLabel.setTextAlignment(UITextAlignmentCenter)

      view.addSubview(headerLabel)
      view
    else
      super
    end
  end

  def tableView(tableView, heightForHeaderInSection:section)
    if section > 0
      38
    else
      super
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if indexPath.section == 0 && indexPath.row < 2
      currentLocation = pagesController.currentLocation
      from = "#{currentLocation.latitude.to_s},#{currentLocation.longitude.to_s}"
      to = "#{model.lat.to_s},#{model.lng.to_s}"

      if indexPath.row == 0

        App.open_url "http://maps.apple.com/?saddr=#{from}&daddr=#{to}"
      else
        App.open_url "comgooglemaps://?saddr=#{from}&daddr=#{to}&directionsmode=walking"
      end
    end
  end
end
