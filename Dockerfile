FROM maven:3.6.3-jdk-8 AS build

RUN git clone https://github.com/genome-nexus/genome-nexus-annotation-pipeline.git
WORKDIR /genome-nexus-annotation-pipeline
RUN cp annotationPipeline/src/main/resources/application.properties.EXAMPLE annotationPipeline/src/main/resources/application.properties
RUN cp annotationPipeline/src/main/resources/log4j.properties.EXAMPLE annotationPipeline/src/main/resources/log4j.properties
RUN sed -i "s|/path/to/logfile.log|/opt/log/logfile.log|g" annotationPipeline/src/main/resources/log4j.properties

RUN mvn clean install

FROM python:3.7-alpine
WORKDIR /opt
RUN apk add openjdk8
COPY --from=build /genome-nexus-annotation-pipeline/annotationPipeline/target/annotationPipeline-1.0.0.jar /opt/scripts/annotator.jar
COPY ["merge_mafs.py", "overlay_gnomad_columns.py", "standardize_mutation_data.py", "variant_notation_converter.py", "/opt/scripts/"]
COPY annotation_suite_wrapper.sh /opt/annotation_suite_wrapper.sh
RUN mkdir /opt/input /opt/output
RUN pip install -U chardet requests