#
#  Copyright (c) 2017 CA. All rights reserved.
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#
## Unlock cURL in LAC
FROM caliveapicreator/5.1.00

USER root

RUN apt-get update \
    && apt-get -y install curl

USER ${ENTRYPOINT_ID}