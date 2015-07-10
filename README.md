Omniauth for edX
================ 

## Basic Usage

    use OmniAuth::Builder do
      provider :edx, ENV['EDX_KEY'], ENV['EDX_SECRET']
    end
