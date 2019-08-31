classdef Utility
  methods
    function event_flag = get_event_flag(obj, num_day)
      num_hour            = num_day * 24;
      mean_event_interval = round(rand() * 5 * 24 + 18 * 24);
      num_event           = ceil(num_hour / mean_event_interval);


      event_flag = zeros(1, num_hour);
      start_at = ceil(rand() * 24 * 24);

      for i = 1:num_event
        event_duration = ceil(rand() * 12 + 6);
        end_at = start_at + event_duration;

        event_flag(start_at:end_at) = 1;

        event_interval = round(rand() - 0.5 + mean_event_interval);
        start_at = end_at + event_interval;
      end

    end

    function signal = clip(obj, signal, lb, ub)
      signal(signal < lb) = lb; 
      signal(signal > ub) = ub; 
    end

    function value = get_event_activity_index(obj)
      value = rand() * 15 + 1;
    end

    function value = get_non_event_activity_index(obj)
      value = rand();
    end

    function clear_signal = get_clear_signal(obj, event_flag)
      num_hour = length(event_flag);
      clear_signal = zeros(1, num_hour);
      for i = 1:num_hour
        if event_flag(i) == 1
          % inside the event, get 0.5 chance to have
          % high activity index
          if rand() < 0.5
            clear_signal(i) = obj.get_event_activity_index();
          else
            clear_signal(i) = obj.get_non_event_activity_index();
          end
        else
          clear_signal(i) = obj.get_non_event_activity_index();
        end
      end
      clear_signal = obj.clip(clear_signal, -1, 30);
    end

    function noisy_signal = get_noisy_signal(obj, clear_signal, rate)
      noisy_signal = clear_signal;
      for i = 1 : length(clear_signal)
        if rand() < rate
          % % 50:50 chance it its either event/non-event
          % if rand() < 0.5
          %   noisy_signal(i) = obj.get_event_activity_index();
          % else
          %   noisy_signal(i) = obj.get_non_event_activity_index();
          % end
          % flip non-event to event
          if clear_signal(i) <= 1
            noisy_signal(i) = obj.get_event_activity_index();
          end
        end
      end
      noisy_signal = obj.clip(noisy_signal, -1, 30);
    end

    function mkdir(obj, algorithm, instance)
      folder = 'result';
      if ~exist(folder), mkdir(folder); end
      folder = sprintf('result/%s', algorithm);
      if ~exist(folder), mkdir(folder); end        
      folder = sprintf('result/%s/%s', algorithm, instance);
      if ~exist(folder), mkdir(folder); end        
    end

    function save_result = save_result(obj, precision, recall, duration, algorithm, instance, seed)
      filename = sprintf('result/%s/%s/%d.txt', algorithm, instance, seed);
      fp = fopen(filename, 'w');
      fprintf(fp, '%f,%f,%f', precision, recall, duration);
      fclose(fp);
    end

    function [precision, recall, duration] = read_result(obj, algorithm, instance, seed)
      filename = sprintf('result/%s/%s/%d.txt', algorithm, instance, seed);
      result = csvread(filename);
      precision = result(1);
      recall    = result(2);
      duration  = result(3);
    end

    function [mp, mr, md, sp, sr, sd] = aggregate_result(obj, algorithm, instance)
      precisions = []; recalls    = []; durations  = [];
      for seed = 1:30
        [precision, recall, duration] = obj.read_result(algorithm, instance, seed);
        precisions = [precisions, precision];
        recalls    = [recalls, recall];
        durations  = [durations, duration];
      end
      mp = mean(precisions); sp = std(precisions);
      mr = mean(recalls);    sr = std(recalls);
      md = mean(durations);  sd = std(durations);
    end

  end
end
